<template>
  <a-modal
    :title="title"
    :width="width"
    :visible="visible"
    switchFullscreen
    @ok="handleOk"
    :okButtonProps="{ class:{'jee-hidden': disableSubmit} }"
    @cancel="handleCancel"
    cancelText="关闭">
    <a-form ref="form" :model="model"  id="myForm1">
      <a-row>
        <a-col :span="24" >
          <a-form-model-item label="項目名稱" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="projectName">
            <a-select v-model="model.projectName" @change="getNetworkIdsNew" placeholder="请选择項目"  :disabled="true">
              <a-select-option v-for="project in projects":value="project.text"  >{{project.text}}</a-select-option>
            </a-select>
          </a-form-model-item>
        </a-col>
        <a-col :span="24">
          <a-form-item label="實例名稱" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="instanceName">
            <a-input v-model="model.instanceName" placeholder="请输入實例名稱" :disabled="true" ></a-input>
          </a-form-item>
        </a-col>
        <a-col :span="24">
          <a-form-item label="描述" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="represent">
            <a-input v-model="model.represent" placeholder="请输入描述" :disabled="true"></a-input>
          </a-form-item>
        </a-col>
        <a-col :span="24" >
          <a-form-item label="鏡像" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="imgId">
            <a-select v-model="model.imgId"  placeholder="请选择鏡像" :disabled="true">
              <a-select-option v-for="imgs in imgIds":value="imgs.value" >{{imgs.text}}</a-select-option>
            </a-select>
          </a-form-item>
        </a-col>
        <a-col :span="24">
          <a-form-item label="刪除實例時是否刪除卷" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="isDelete">
            <j-dict-select-tag type="radioButton" v-model="model.isDelete" dictCode="is_delete"  placeholder="请选择刪除實例時是否刪除卷" :disabled="true"/>
          </a-form-item>
        </a-col>
        <a-col :span="24">
          <a-form-item label="實例類型" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="flavorId">
            <a-select v-model="model.flavorId"  placeholder="请选择實例類型" >
              <a-select-option v-for="flavors in flavorIds":value="flavors.value">{{flavors.text}}</a-select-option>
            </a-select>
          </a-form-item>
        </a-col>
        <a-col :span="24">
          <a-form-item label="合约日期启" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="startTime" >
            <j-date  v-model="model.startTime"  placeholder="请选择开始时间" date-format="YYYY-MM-DD" style="width: 60%" ></j-date>
          </a-form-item>
        </a-col>
        <a-col :span="24">
          <a-form-item label="合约日期迄" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="endTime">
            <j-date v-model="model.endTime" placeholder="请选择终止时间" date-format="YYYY-MM-DD" style="width: 60%" ></j-date>
          </a-form-item>
        </a-col>
        <a-col :span="24">
          <a-form-item label="安全組" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="securityName">
            <a-select  v-model="model.securityName" placeholder="请选择安全組" >
              <a-select-option v-for="securitys in securityNames":value="securitys.text" >{{securitys.text}}</a-select-option>
            </a-select>
          </a-form-item>
        </a-col>
        <a-col :span="24">
          <a-form-item label="網絡" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="networkId">
            <a-select  v-model="model.networkId" placeholder="请选择網絡" :disabled="true">
              <a-select-option v-for="networks in networkIds":value="networks.value" >{{networks.text}}</a-select-option>
            </a-select>
          </a-form-item>
        </a-col>
      </a-row>
    </a-form>
  </a-modal>
</template>

<script>

  import { httpAction, getAction } from '@/api/manage'
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
            { required: true, message: '请输入實例名稱!'},
          ],
          imgId: [
            { required: true, message: '请输入鏡像id!'},
          ],
          flavorId: [
            { required: true, message: '请输入實例類型id!'},
          ],
          networkId: [
            { required: true, message: '请选择网络'},
          ],
          startTime: [
            { required: true, message: '请输入开始时间!'},
          ],
          endTime: [
            { required: true, message: '请输入结束时间!'},
          ]
        },

        url: {
          getProject: "/os/osApply/getProject",
          adjust: "/os/osApply/adjust",
          getImg: "/os/osApply/getImg",
          getFlavor: "/os/osApply/getFlavor",
          getSecurity: "/os/osApply/getSecurity",
          getNetwork: "/os/osApply/getNetwork"

        },
        projects:[],
        imgIds:[],
        flavorIds:[],
        securityNames:[],
        networkIds:[]
      }
    },
    created () {
      //备份model原始值
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
        let formData={
          projectName: this.model.projectName,
          projectId: this.projectId,
          instanceName: this.model.instanceName,
          options: "2",
          represent: this.model.represent,
          imgId: this.model.imgId,
          isDelete: this.model.isDelete,
          flavorId: this.model.flavorId,
          securityName: this.model.securityName,
          networkId: this.model.networkId,
          startTime: this.model.startTime,
          endTime: this.model.endTime,
          vmId: this.model.vmId
        }
        httpAction(httpurl,formData,method).then((res)=>{
          if(res.success){
            that.$message.success(res.message);
            that.loadData();
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