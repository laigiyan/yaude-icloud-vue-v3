<template>
  <a-spin :spinning="confirmLoading">
    <j-form-container :disabled="formDisabled">
      <a-form-model  ref="form" :model="model" :rules="validatorRules" slot="detail">
        <a-row>
          <a-col :span="24">
            <a-form-model-item label="實例名稱" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="instanceName">
              <a-input v-model="model.instanceName" placeholder="请输入實例名稱"  :disabled=editable></a-input>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="描述" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="represent">
              <a-input v-model="model.represent" placeholder="请输入描述"  :disabled=editable></a-input>
            </a-form-model-item>
          </a-col>
          <a-col :span="24" >
            <a-form-model-item label="鏡像" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="imgId">
             <!-- <j-dict-select-tag type="list" v-model="model.imgId" dictCode="" placeholder="请选择鏡像id" />-->
              <a-select v-model="model.imgId"  placeholder="请选择鏡像" :disabled=editable>
                <a-select-option v-for="imgs in imgIds":value="imgs.value" >{{imgs.text}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="刪除實例時是否刪除卷" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="isDelete">
              <j-dict-select-tag type="radioButton" v-model="model.isDelete" dictCode="is_delete" :disabled=editable placeholder="请选择刪除實例時是否刪除卷" />
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="實例類型" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="flavorId">
              <!--<j-dict-select-tag type="list" v-model="model.flavorId" dictCode="" placeholder="请选择實例類型id" />-->
              <a-select v-model="model.flavorId"  placeholder="请选择實例類型" :disabled=justable>
                <a-select-option v-for="flavors in flavorIds":value="flavors.value">{{flavors.text}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="合约日期启" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="startTime">
              <j-date v-model="model.startTime" placeholder="请选择开始时间" date-format="YYYY-MM-DD" style="width: 60%" :disabled=justable></j-date>
            <!--  <a-range-picker :default-value="[model.startTime, model.endTime]"  style="width: 100%"></a-range-picker>-->
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="合约日期迄" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="endTime">
              <j-date v-model="model.endTime" placeholder="请选择终止时间" date-format="YYYY-MM-DD" style="width: 60%" :disabled=justable></j-date>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="安全組" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="securityName">
              <!--<j-dict-select-tag type="list" v-model="model.securityName" dictCode="" placeholder="请选择安全組" />-->
              <a-select v-model="model.securityName"  placeholder="请选择安全組" :disabled=justable>
                <a-select-option v-for="securitys in securityNames":value="securitys.text" >{{securitys.text}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="網絡" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="networkId">
              <!--<j-dict-select-tag type="list" v-model="model.networkId" dictCode="" placeholder="请选择網絡" />-->
              <a-select v-model="model.networkId"  placeholder="请选择網絡" :disabled=editable>
                <a-select-option v-for="networks in networkIds":value="networks.value" >{{networks.text}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>
        </a-row>
      </a-form-model>
    </j-form-container>
  </a-spin>
</template>

<script>

  import { httpAction, getAction } from '@/api/manage'
  import { validateDuplicateValue } from '@/utils/util'
  import  moment from "moment"

  export default {
    name: 'OsApplyForm',
    components: {
    },
    props: {
      //表单禁用
      disabled: {
        type: Boolean,
        default: false,
        required: false

      }
    },
    data () {
      return {
        model:{
         },
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
          add: "/os/osApply/add",
          edit: "/os/osApply/edit",
          queryById: "/os/osApply/queryById",
          readData: "/os/osApply/readData",
          getImg: "/os/osApply/getImg",
          getFlavor: "/os/osApply/getFlavor",
          getSecurity: "/os/osApply/getSecurity",
          getNetwork: "/os/osApply/getNetwork",
          adjust: "/os/osApply/adjust"

        },
        imgIds:[],
        flavorIds:[],
        securityNames:[],
        networkIds:[],
        dateFormat:'YYYY-MM-DD',
        editable: false,
        justable: false

      }
    },
    computed: {
      formDisabled(){
        return this.disabled
      },

    },
    created () {
       //备份model原始值
     // this.getdata();

      this.modelDefault = JSON.parse(JSON.stringify(this.model));
      this.getImgs(this.modelDefault);
      this.getFlavorIds(this.modelDefault);
      this.getSecurityNames(this.modelDefault);
      this.getNetworkIds(this.modelDefault);
    },
    methods: {
      add () {
        this.edit(this.modelDefault);
      },
      edit (record) {
        debugger
        this.model = Object.assign({}, record);
        this.visible = true;
        if(this.model.options=="1" || (this.model.options=="2" && this.model.status!=null) ){
          this.editable=true
          this.justable=true
        }else if(this.model.options=="2" && this.model.status==null){
          this.editable=true
          this.justable=false
        }



      },
      submitForm () {
        //let times = this.model.startTime;
        const that = this;
        // 触发表单验证
        this.$refs.form.validate(valid => {
          if (valid) {
            that.confirmLoading = true;
            let httpurl = '';
            let method = '';
            if(!this.model.id){
              httpurl+=this.url.add;
              method = 'post';
            }else{
              httpurl+=this.url.edit;
               method = 'put';
            }
            httpAction(httpurl,this.model,method).then((res)=>{
              if(res.success){
                that.$message.success(res.message);
                that.$emit('ok');
              }else{
                that.$message.warning(res.message);
              }
            }).finally(() => {
              that.confirmLoading = false;
            })
          }

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
    }
  }
</script>