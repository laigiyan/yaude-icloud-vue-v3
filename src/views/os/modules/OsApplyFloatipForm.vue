<template>
  <a-spin :spinning="confirmLoading">
    <j-form-container :disabled="formDisabled">
      <a-form-model ref="form" :model="model" :rules="validatorRules" slot="detail">
        <a-row>
          <a-col :span="24" >
            <a-form-model-item label="項目名稱" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="projectId">
              <a-select v-model="model.projectId" @change="getAll" placeholder="請選擇項目"  :disabled=editable>
                <a-select-option v-for="project in projects":value="project.value"  >{{project.text}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="網絡名稱" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="networkName">
            <!--  <a-input v-model="model.networkName" placeholder="請輸入網絡名稱"  ></a-input>-->
              <a-select v-model="model.networkName"   placeholder="請選擇網絡名稱" :disabled="editable">
                <a-select-option v-for="network in networks":value="network.text" >{{network.text}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="子網名稱" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="subnetName">
             <!-- <a-input v-model="model.subnetName" placeholder="請輸入子網名稱"  ></a-input>-->
              <a-select v-model="model.subnetName" placeholder="請選擇子網名稱" @click.native="getSubnets" :disabled="editable">
                <a-select-option v-for="subnet in subnets":value="subnet.text" >{{subnet.text}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>
          <!--<a-col :span="24">
            <a-form-model-item label="浮動ip" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="floatIp">
              &lt;!&ndash;<a-input v-model="this.floatip" placeholder="請輸入浮動ip"  ></a-input>&ndash;&gt;
              <a-select v-model="model.floatIp" @change="getFloatip" placeholder="請選擇子網名稱" :disabled="editable" >
                <a-select-option v-for="floatip in floatips":value="floatip.value" >{{floatip.value}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>-->
          <a-col :span="24">
            <a-form-model-item label="描述" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="represent">
              <a-input v-model="model.represent" placeholder="請輸入描述"  :disabled="editable"></a-input>
            </a-form-model-item>
          </a-col>
          <!--<a-col :span="24">
            <a-form-model-item label="申請時間" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="startTime">
              <j-date placeholder="請選擇申請時間" v-model="model.startTime"  style="width: 100%" :disabled="justable"/>
            </a-form-model-item>
          </a-col>-->
          <a-col :span="24">
            <a-form-model-item label="合約日期啟" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="startTime">
              <j-date v-model="model.startTime" placeholder="請選擇開始時間" date-format="YYYY-MM-DD" style="width: 60%" :disabled=justable></j-date>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="合約日期止" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="endTime">
              <j-date v-model="model.endTime" placeholder="請選擇終止時間" date-format="YYYY-MM-DD" style="width: 60%" :disabled=justable></j-date>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="映射vm_ip" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="mapperIp">
              <a-input v-model="model.mapperIp" placeholder="請輸入映射vm_ip"  :disabled="justable"></a-input>
            </a-form-model-item>
          </a-col>
          <a-col :span="24" v-show="showoption">
            <a-form-model-item label="審核意見" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="optionsText" >
              <a-textarea v-model="model.optionsText" placeholder="請輸入審核意見" ></a-textarea>
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

  export default {
    name: 'OsApplyFloatipForm',
    components: {
    },
    props: {
      //表單禁用
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
          networkName: [
            { required: true, message: '請選擇網絡名稱!'},
          ],
          subnetName: [
            { required: true, message: '請選擇子網!'},
          ],
          floatIp: [
            { required: true, message: '請選擇浮動ip!'},
          ],
          startTime: [
            { required: true, message: '請輸入開始時間!'},
          ],
          endTime: [
            { required: true, message: '請輸入結束時間!'},
          ],
          projectId:[
            { required: true, message: '請選擇項目'},
          ]
        },
        url: {
          add: "/os/osApplyFloatip/add",
          edit: "/os/osApplyFloatip/edit",
          queryById: "/os/osApplyFloatip/queryById",
          getNetwork: "/os/osApplyFloatip/getNetwork",
          getSubnets: "/os/osApplyFloatip/getSubnets",
          getProject: "/os/osApply/getProject",
         // getFloatip: "/os/osApplyFloatip/getFloatip",
          agree: "/os/osOption/agree",
          refuse: "/os/osOption/refuse"
        },
        networks:[],
        subnets:[],
        floatips:[],
        projects:[],
        editable: false,
        justable: false,
        showoption: false
      }
    },
    computed: {
      formDisabled(){
        return this.disabled
      },
    },
    created () {
       //備份model原始值
      this.modelDefault = JSON.parse(JSON.stringify(this.model));
     // this.getNetwork(this.modelDefault);
      this.getProjects(this.modelDefault);
    },
    methods: {
      add () {
        this.edit(this.modelDefault);
      },
      edit (record) {
        this.model = Object.assign({}, record);
        this.visible = true;
        if(this.model.id){
          this.getNetwork();
        }
        this.showoption = this.model.showoption;
        if(this.model.options=="1" || (this.model.options=="2" && this.model.status!=null) ){
          this.editable=true
          this.justable=true
        }else if(this.model.options=="2" && this.model.status==null){
          this.editable=true
          this.justable=false
        }
      },
      submitForm () {
        const that = this;
        this.projects.forEach((r)=>{
          if(r.value==that.model.projectId){
            that.model.projectName = r.text;
          }
        })

        // 觸發表單驗證
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
      //同意
      agree(){
        const that = this;
        let method = "post";
        this.model.applyType = "2";
        this.model.optionsType="1";
        let httpurl = this.url.agree;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            that.$message.success(res.message);
          }else{
            that.$message.warning(res.message);
          }
        }).finally(() => {
          that.confirmLoading = false;
        })
      },
      //拒絕
      refuse(){
        const that = this;
        this.model.applyType = "2";
        this.model.optionsType="0";
        let method = "post";
        let httpurl = this.url.refuse;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            that.$message.success(res.message);
            that.$emit('ok');
            that.loadData();
          }else{
            that.$message.warning(res.message);
          }
        }).finally(() => {
          that.confirmLoading = false;
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
      getAll(){
        this.getNetwork();
      },
      getNetwork(){
        this.networks=[];
        let record = this.model;
        this.model = Object.assign({}, record);
        let method = "post";
        let httpurl = this.url.getNetwork;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.networks.push({
                value:r.networkId,
                text:r.networkName
              })
            })
          }
        })
      },
      getSubnets(){
        const that = this;
        this.networks.forEach((r)=>{
          if(r.text==that.model.networkName){
            that.model.networkId = r.value;
          }
        })
        this.subnets=[];
        let method = "post";
        let httpurl = this.url.getSubnets;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.subnets.push({
                value:r.subnetId,
                text:r.subnetName
              })
            })
          }
        })
      },

    }
  }
</script>