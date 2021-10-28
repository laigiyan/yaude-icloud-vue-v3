<template>
  <a-modal
    :title="title"
    :width="width"
    :visible="visible"
    switchFullscreen
    @ok="handleOk"
    :okButtonProps="{ class:{'jee-hidden': disableSubmit} }"
    @cancel="handleCancel"
    cancelText="關閉">
    <a-form ref="form" :model="model"  id="myForm1">
      <a-row>
        <a-col :span="24" >
          <a-form-model-item label="專案名稱" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="projectName">
            <a-select v-model="model.projectName" @change="getNetworkIdsNew" placeholder="請選擇專案"  :disabled="true">
              <a-select-option v-for="project in projects":value="project.text"  >{{project.text}}</a-select-option>
            </a-select>
          </a-form-model-item>
        </a-col>
        <a-col :span="24">
          <a-form-item label="實例名稱" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="instanceName">
            <a-input v-model="model.instanceName" placeholder="請輸入實例名稱" :disabled="true" ></a-input>
          </a-form-item>
        </a-col>
        <a-col :span="24">
          <a-form-item label="描述" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="represent">
            <a-input v-model="model.represent" placeholder="請輸入描述" :disabled="true"></a-input>
          </a-form-item>
        </a-col>
        <a-col :span="24" >
          <a-form-item label="映像檔" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="imgId">
            <a-select v-model="model.imgId"  placeholder="請選擇映像檔" :disabled="true">
              <a-select-option v-for="imgs in imgIds":value="imgs.value" >{{imgs.text}}</a-select-option>
            </a-select>
          </a-form-item>
        </a-col>
        <a-col :span="24">
          <a-form-item label="刪除實例時是否刪除卷" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="isDelete">
            <j-dict-select-tag type="radioButton" v-model="model.isDelete" dictCode="is_delete"  placeholder="請選擇刪除實例時是否刪除卷" :disabled="true"/>
          </a-form-item>
        </a-col>
        <a-col :span="24">
          <a-form-item label="虛擬硬體樣板" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="flavorId">
            <a-select v-model="model.flavorId"  placeholder="請選擇虛擬硬體樣板" >
              <a-select-option v-for="flavors in flavorIds":value="flavors.value">{{flavors.text}}</a-select-option>
            </a-select>
          </a-form-item>
        </a-col>
        <a-col :span="24">
          <a-form-item label="合約日期啟" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="startTime" >
            <j-date  v-model="model.startTime"  placeholder="請選擇開始時間" date-format="YYYY-MM-DD" style="width: 60%" ></j-date>
          </a-form-item>
        </a-col>
        <a-col :span="24">
          <a-form-item label="合約日期迄" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="endTime">
            <j-date v-model="model.endTime" placeholder="請選擇終止時間" date-format="YYYY-MM-DD" style="width: 60%" ></j-date>
          </a-form-item>
        </a-col>
        <a-col :span="24">
          <a-form-item label="安全群組" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="securityName">
            <a-select  v-model="model.securityName" placeholder="請選擇安全群組" >
              <a-select-option v-for="securitys in securityNames":value="securitys.text" >{{securitys.text}}</a-select-option>
            </a-select>
          </a-form-item>
        </a-col>
        <a-col :span="24">
          <a-form-item label="網路" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="networkId">
            <a-select  v-model="model.networkId" placeholder="請選擇網路" :disabled="true">
              <a-select-option v-for="networks in networkIds":value="networks.value" >{{networks.text}}</a-select-option>
            </a-select>
          </a-form-item>
        </a-col>
        <a-col :span="24">
          <a-form-model-item label="密鑰" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="keypairsId">
            <a-select v-model="model.keypairsId"  placeholder="請選擇密鑰" style="width: 60%" :disabled="true" >
              <a-select-option v-for="key in keyNames":value="key.value" >{{key.text}}</a-select-option>
            </a-select>
            <a-button @click="downPrivateKey" type="primary">下載密鑰</a-button>
          </a-form-model-item>
        </a-col>
      </a-row>
    </a-form>
  </a-modal>
</template>

<script>

  import { httpAction, getAction,downloadFile } from '@/api/manage'
  import pick from 'lodash.pick'
  import moment from 'moment'
  export default {
    name: 'OsAdjustModal',
    components: {
    },
    //el: '#myForm1',
    data () {
      return {
        model:{
        },
        form: this.$form.createForm(this),
        title:'',
        width:800,
        visible: false,
        disableSubmit: false,
        labelCol: {
          xs: { span: 24 },
          sm: { span: 5 },
        },
        wrapperCol: {
          xs: { span: 24 },
          sm: { span: 16 },
        },
        confirmLoading: false,
        validatorRules: {
          instanceName: [
            { required: true, message: '請輸入實例名稱!'},
          ],
          imgId: [
            { required: true, message: '請輸入映像檔id!'},
          ],
          flavorId: [
            { required: true, message: '請輸入虛擬硬體樣板id!'},
          ],
          networkId: [
            { required: true, message: '請選擇網路'},
          ],
          startTime: [
            { required: true, message: '請輸入開始時間!'},
          ],
          endTime: [
            { required: true, message: '請輸入結束時間!'},
          ]
        },

        url: {
          getProject: "/os/osApply/getProject",
          adjust: "/os/osApply/adjust",
          getImg: "/os/osApply/getImg",
          getFlavor: "/os/osApply/getFlavor",
          getSecurity: "/os/osApply/getSecurity",
          getNetwork: "/os/osApply/getNetwork",
          getKeyPairs: "/os/osApply/getKeyPairs",
          getPrivateKey: "openstack/osKeyPairs/getPrivateKey",

        },
        projects:[],
        imgIds:[],
        flavorIds:[],
        securityNames:[],
        networkIds:[],
        keyNames:[]
      }
    },
    created () {
      //備份model原始值
      // this.getdata();


    },
    methods: {
      adjust (record) {
        this.form.resetFields();
        this.model = Object.assign({}, record);
        this.visible = true;
        this.getFlavorIds(this.model);
        this.getSecurityNames( this.model);
        this.getProjects(this.model);
        this.getImgs(this.model);
        this.getPrivateKeys(this.model);
        // this.getFlavorIds(this.model);
        // this.getSecurityNames(this.model);
        this.getNetworkIds(this.model);
      },
      handleOk () {
        let projectId = "";
        let that = this;
        let method = 'post';
        let httpurl=this.url.adjust;
        that.projects.forEach((r)=>{
          if(r.text==that.model.projectName){
            that.projectId = r.value;
          }
        })
        that.imgIds.forEach((r)=>{
          if(r.value==that.model.imgId){
            this.model.imgName= r.text;
          }
        })
        that.flavorIds.forEach((r)=>{
          if(r.value==that.model.flavorId){
            this.model.flavorName= r.text;
          }
        })

        let formData={
          projectName: this.model.projectName,
          projectId: this.projectId,
          instanceName: this.model.instanceName,
          options: "2",
          represent: this.model.represent,
          imgId: this.model.imgId,
          imgName: this.model.imgName,
          isDelete: this.model.isDelete,
          flavorId: this.model.flavorId,
          flavorName: this.model.flavorName,
          securityName: this.model.securityName,
          networkId: this.model.networkId,
          startTime: this.model.startTime,
          endTime: this.model.endTime,
          vmId: this.model.vmId,
          keypairsId: this.model.keypairsId
        }
        httpAction(httpurl,formData,method).then((res)=>{
          if(res.success){
            that.$message.success(res.message);
            that.$emit('ok');
          }else{
            that.$message.warning(res.message);
          }
        }).finally(() => {
          that.confirmLoading = false;
          that.close();
        })
      },

      getImgs(record){
        this.model = Object.assign({}, record);
        let method = "post";
        let httpurl = this.url.getImg;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.imgIds.push({
                value:r.imgId,
                text:r.imgName
              })
            })
          }
        })
      },
      getFlavorIds(record){
        this.model = Object.assign({}, record);
        let method = "post";
        let httpurl = this.url.getFlavor;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.flavorIds.push({
                value:r.flavorId,
                text:r.flavorName
              })
            })
          }
        })
      },
      getSecurityNames(record){
        this.model = Object.assign({}, record);
        let method = "post";
        let httpurl = this.url.getSecurity;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.securityNames.push({
                value:r.value,
                text:r.securityName
              })
            })
          }
        })
      },
      getNetworkIds(record){
        this.model = Object.assign({}, record);
        let method = "post";
        let httpurl = this.url.getNetwork;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.networkIds.push({
                value:r.networkId,
                text:r.networkName
              })
            })
          }
        })
      },
      getNetworkIdsNew(){
        let record = this.model;
        this.model = Object.assign({}, record);
        let method = "post";
        let httpurl = this.url.getNetwork;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.networkIds.push({
                value:r.networkId,
                text:r.networkName
              })
            })
          }
        })
      },
      getProjects(record){
        this.model = Object.assign({}, record);
        let method = "post";
        let httpurl = this.url.getProject;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.projects.push({
                value:r.projectId,
                text:r.projectName,
              })
            })
          }
        })
      },
      getPrivateKeys(record){
        this.keyNames=[];
        this.model = Object.assign({}, record);
        let method = "post";
        let httpurl = this.url.getKeyPairs;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.keyNames.push({
                value:r.keypairsId,
                text:r.keyName,
                key:r.privateKey
              })
            })
          }
        })
      },
      downPrivateKey(){
        this.keyNames.forEach((r)=>{
          if(r.value==this.model.keypairsId){
            this.model.keyName = r.text;
            this.model.privateKey = r.key;
          }
        })
        let keyName =  this.model.keyName;
        downloadFile(this.url.getPrivateKey,keyName+'.pem',this.model);
      },

      close () {
        this.$emit('close');
        this.visible = false;
      },


      submitCallback(){
        this.$emit('ok');
        this.visible = false;
      },
      handleCancel () {
        this.close()
      }
    }
  }
</script>